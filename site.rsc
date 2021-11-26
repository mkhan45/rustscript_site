# reads projects/resume from the toml file
let projects = "assets/portfolio.toml"
    |> read_file
    |> parse_toml
    |> fn(m) => m("projects")
    |> map(
	fn(project) => {
	    let route = "/portfolio/details/" + project("projectName") + ".html"
	    %{"projectDetailsRoute" => route | project}
	}, _
    )

let resume = "assets/resume.toml" 
    |> read_file 
    |> parse_toml 

# each endpoint is a route that uses a generator function
# to generate the page
let endpoints = %{
    "" => fn(gen_state) => {
	template_file_string("templates/index.html", gen_state)
    },
    "index.html" => fn(gen_state) => {
	template_file_string("templates/index.html", gen_state)
    },
    "resume.html" => fn(gen_state) => {
	let state = merge_maps(resume, gen_state)
	template_file_string("templates/resume.html", state)
    },
    "portfolio.html" => fn(gen_state) => {
	let state = %{"projects" => projects | gen_state}
	template_file_string("templates/portfolio.html", state)
    },
    "portfolio/details/{{project_name}}.html" => fn(gen_state) => {
	# route arguments are added to gen_state

	let project_name = gen_state("project_name")
	let project = find(fn(p) => p("projectName") == project_name, projects)
	
	let state = merge_maps(project, gen_state)
	template_file_string("templates/portfolio_details.html", state)
    },
    "css/{{css_path}}" => fn(%{"css_path" => path}) => {
	read_file("assets/css/" + path)
    },
    "js/{{js_path}}" => fn(%{"js_path" => path}) => {
	read_file("assets/js/" + path)
    },
    "*" => fn(_) => "404"
}

let global_state = %{
    "ghicon" => read_file("templates/gh-icon.svg"),
    "liicon" => read_file("templates/li-icon.svg"),
    "linkicon" => read_file("templates/link-icon.svg")
}

serve_endpoints(:tls, 8000, global_state, endpoints)
