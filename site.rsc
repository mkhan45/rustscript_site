let projects = "assets/portfolio.toml"
    |> read_file
    |> parse_toml
    |> fn(m) => m("projects")

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
	let projects = projects
	    |> map(
		fn(%{"projectName" => name} as p) => 
		    %{"projectDetailsRoute" => gen_state(:base_route) + "/portfolio/details/" + name | p}
	    , _)
	
	let state = %{"projects" => projects | gen_state}
	template_file_string("templates/portfolio.html", state)
    },
    "portfolio/details/{{project_name}}" => fn(gen_state) => {
	let project_name = gen_state("project_name")
	let project = find(fn(p) => p("projectName") == project_name, projects)
	
	let state = merge_maps(project, gen_state)
	template_file_string("templates/portfolio_details.html", state)
    },
    "css/base.css" => fn(_) => {
	read_file("assets/css/base.css")
    },
    "js/pixi.min.js" => fn(_) => {
	read_file("assets/js/pixi.min.js")
    },
    "js/index.js" => fn(_) => {
	read_file("assets/js/index.js")
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

let project_pages = {
    let projects = "assets/portfolio.toml" 
	|> read_file 
	|> parse_toml 
	|> fn(m) => m("projects")

    ["portfolio/details/" + p("projectName") for p in projects]
}

let pages = base_pages + project_pages

let global_state = %{
    "header" => read_file("templates/header.html"),
    "footer" => read_file("templates/footer.html"),
    "ghicon" => read_file("templates/gh-icon.svg"),
    "liicon" => read_file("templates/li-icon.svg"),
    "linkicon" => read_file("templates/link-icon.svg")
}

gen_site("https://mkhan45.github.io/rustscript_site/", endpoints, pages, "docs", global_state)
