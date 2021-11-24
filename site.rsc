# reads projects from the toml file
let projects = "assets/portfolio.toml"
    |> read_file
    |> parse_toml
    |> fn(m) => m("projects")

# each endpoint is a route that uses a generator function
# to generate the page
let endpoints = %{
    "index.html" => fn(gen_state) => {
	template_file_string("templates/index.html", gen_state)
    },
    "resume.html" => fn(gen_state) => {
	let state = "assets/resume.toml" 
	    |> read_file 
	    |> parse_toml 
	    |> merge_maps(_, gen_state)
	template_file_string("templates/resume.html", state)
    },
    "portfolio.html" => fn(gen_state) => {
	# adds a route to each project, must be done until templates
	# can evaluate expressions
	let projects = 
	    map(
		fn(%{"projectName" => name} as project) => {
		    let route = gen_state(:base_route) + "/portfolio/details/" + name + ".html"
		    %{"projectDetailsRoute" => route | project}
		},
		projects
	    )
	
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
    }
}

let base_pages = [
    "index.html",
    "resume.html",
    "portfolio.html",
    "css/base.css",
    "js/pixi.min.js",
    "js/index.js"
]
let project_pages = ["portfolio/details/" + p("projectName") + ".html" for p in projects]
let pages = base_pages + project_pages

let global_state = %{
    "ghicon" => read_file("templates/gh-icon.svg"),
    "liicon" => read_file("templates/li-icon.svg"),
    "linkicon" => read_file("templates/link-icon.svg")
}

gen_site("https://mkhan45.github.io/rustscript_site/", endpoints, pages, "docs", global_state)
