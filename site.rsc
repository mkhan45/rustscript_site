# reads projects/resume from the toml file
let read_projects() = "assets/portfolio.toml"
    |> read_file
    |> parse_toml
    |> fn(m) => m("projects")
    |> map(
	fn(project) => {
	    let route = "/portfolio/details/" + project("projectName") + ".html"
	    %{"projectDetailsRoute" => route | project}
	}, _
    )

let read_resume() = "assets/resume.toml"
    |> read_file
    |> parse_toml

let pass_hash() = "$2y$06$mJH2mI0Pvdos6cV0BFjlmukI.UOvSH4b5SNZZhIZdwDqxsZXc9Xc."

let read_meme_page(page) = {
    let rows = "assets/memes.txt"
	    |> read_file
	    |> to_charlist
	    |> split(_, "\n")
	    |> map(concat, _)
	    |> drop(page * 12, _)
	    |> take(12, _)
	    |> map(to_charlist, _)
	    |> map(split(_, " "), _)
	    |> map(fn(ls) => map(concat, ls), _)

    # super clunky because templates cant eval expressions yet
    let to_meme([type, name, url]) = {
	let (is_img, is_youtube, is_mp4) = match type
	    | "image" -> (T, (), ())
	    | "Youtube" -> ((), T, ())
	    | "MP4" | "mp4" -> ((), (), T)
	
	%{
	    "type" => type,
	    "name" => name,
	    "url" => url,
	    "is_img" => is_img,
	    "is_youtube" => is_youtube,
	    "is_mp4" => is_mp4
	}
    }

    map(to_meme, rows)
}

# each endpoint is a route that uses a generator function
# to generate the page
let endpoints = %{
    "" => fn(gen_state, server_state) => {
	template_file_string("templates/index.html", gen_state)
    },
    "index.html" => fn(gen_state, server_state) => {
	template_file_string("templates/index.html", gen_state)
    },
    "resume.html" => fn(gen_state, %{resume}) => {
	let state = merge_maps(resume, gen_state)
	template_file_string("templates/resume.html", state)
    },
    "portfolio.html" => fn(gen_state, %{projects}) => {
	let state = %{"projects" => projects | gen_state}
	template_file_string("templates/portfolio.html", state)
    },
    "portfolio/details/{{project_name}}.html" => fn(gen_state, %{projects}) => {
	# route arguments are added to gen_state

	let project_name = gen_state("project_name")
	let project = find(fn(p) => p("projectName") == project_name, projects)
	
	let state = merge_maps(project, gen_state)
	template_file_string("templates/portfolio_details.html", state)
    },
    "memes" => fn(gen_state, _) => {
	let memes = read_meme_page(0)
	let state = %{"memes" => memes, "prev_page" => "-1", "next_page" => "1" | gen_state}
	template_file_string("templates/memes.html", state)
    },
    "memes/submit" => fn(gen_state, _) => {
	let memes = read_meme_page(0)
	let state = %{"memes" => memes | gen_state}
	template_file_string("templates/meme_submit.html", state)
    },
    (:post, "memes/submit") => fn(gen_state, server_state) => {
	if let (:ok, %{
	    "type" => type,
	    "title" => title,
	    "url" => url,
	    "password" => password
	}) = gen_state(:body) |> parse_urlencoded then {

	    if validate_pass(password, pass_hash()) then {
		let row = concat_sep([type, title, url], " ")
		let file_contents = read_file("assets/memes.txt")
		let new_file_contents = row + "\n" + file_contents

		write_file("assets/memes.txt", new_file_contents)
		("", server_state, %{"Location" => "/memes/submit"}, 302)
	    } else {
		"incorrect password"
	    }

	} else {
	    "invalid request"
	}
    },
    "memes/{{page}}" => fn(gen_state, _) => {
	match string_to_int(gen_state("page"))
	    | (:ok, page) -> {
		let prev_page = to_string(page - 1)
		let next_page = to_string(page + 1)
		let page = if page < 0 then {
		    let n_pages = "assets/memes.txt"
			|> read_file
			|> to_charlist
			|> split(_, "\n")
			|> length
			|> div(_, 12)
			|> truncate

		    n_pages + page
		} else {
		    page
		}

		let memes = read_meme_page(page)
		let state = %{"memes" => memes, "prev_page" => prev_page, "next_page" => next_page | gen_state}
		template_file_string("templates/memes.html", state)
	    }
	    | :err -> {
		"Invalid Page"
	    }
    },
    "signup" => fn(gen_state, _) => {
	template_file_string("templates/signup.html", gen_state)
    },
    "css/{{css_path}}" => fn(%{"css_path" => path}, server_state) => {
	match read_file("assets/css/" + path)
	    | (:err, _) -> "404"
	    | file -> (file, server_state, %{"Content-Type" => "text/css"}, 200)
    },
    "js/{{js_path}}" => fn(%{"js_path" => path}, server_state) => {
	match read_file("assets/js/" + path)
	    | (:err, _) -> "404"
	    | file -> (file, server_state, %{"Content-Type" => "application/javascript"}, 200)
    },
    "img/{{img_path}}" => fn(%{"img_path" => path}, server_state) => {
	match read_file("assets/img/" + path)
	    | (:err, _) -> "404"
	    | file -> (file, server_state, %{"Content-Type" => "img/png"}, 200)
    },
    "reload_cache" => fn(_, server_state) => {
	("success", %{projects: read_projects(), resume: read_resume() | server_state}, %{}, 200)
    },
    (:any, "*") => fn(_, server_state) => ("404", server_state, %{}, 404)
}

let global_state = %{
    "ghicon" => read_file("templates/gh-icon.svg"),
    "liicon" => read_file("templates/li-icon.svg"),
    "linkicon" => read_file("templates/link-icon.svg")
}

serve_endpoints(:tls, 8000, global_state, %{projects: read_projects(), resume: read_resume()}, endpoints)
