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
    "css/{{css_path}}" => fn(%{"css_path" => path}, server_state) => {
	match read_file("assets/css/" + path)
	    | (:err, _) -> "404"
	    | file -> (file, server_state, %{"Content-Type" => "text/css"})
    },
    "js/{{js_path}}" => fn(%{"js_path" => path}, server_state) => {
	match read_file("assets/js/" + path)
	    | (:err, _) -> "404"
	    | file -> (file, server_state, %{"Content-Type" => "application/javascript"})
    },
    "reload_cache" => fn(_, server_state) => {
	("success", %{projects: read_projects(), resume: read_resume() | server_state})
    },
    "*" => fn(_, _) => "404"
}

let global_state = %{
    "ghicon" => read_file("templates/gh-icon.svg"),
    "liicon" => read_file("templates/li-icon.svg"),
    "linkicon" => read_file("templates/link-icon.svg")
}

serve_endpoints(:tls, 8000, global_state, %{projects: read_projects(), resume: read_resume()}, endpoints)
