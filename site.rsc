let endpoints = %{
    ("index.html", "index") => fn(gen_state) => {
	template_file_string("templates/index.html", gen_state)
    },
    ("resume.html", "resume") => fn(gen_state) => {
	let state = "assets/resume.toml" 
	    |> read_file 
	    |> parse_toml 
	    |> merge_maps(_, gen_state)
	template_file_string("templates/resume.html", state)
    },
    ("portfolio.html", "portfolio") => fn(gen_state) => {
	let projects = "assets/portfolio.toml" 
	    |> read_file 
	    |> parse_toml 
	    |> fn(m) => m("projects")
	    |> map(
		fn(%{"projectName" => name} as p) => 
		    %{"projectDetailsRoute" => "portfolio/details/" + name | p}
	    , _)
	
	let state = %{"projects" => projects | gen_state}
	template_file_string("templates/portfolio.html", state)
    },
    ("css/base.css", "base_css") => fn(_) => {
	read_file("assets/css/base.css")
    },
    ("js/pixi.min.js", "pixijs") => fn(_) => {
	read_file("assets/js/pixi.min.js")
    },
    ("js/index.js", "indexjs") => fn(_) => {
	read_file("assets/js/index.js")
    }
}

let detail_endpoints = {
    let projects = "assets/portfolio.toml"
	|> read_file 
	|> parse_toml
	|> fn(m) => m("projects")

    let fold_step(acc, proj) = {
	let route = "portfolio/details/" + proj("projectName") + ".html"
	let route_name = "portfolio_details_" + proj("projectName")
	let gen_fn = fn(gen_state) => {
	    let state = merge_maps(proj, gen_state)
	    template_file_string("templates/portfolio_details.html", state)
	}

	%{(route, route_name) => gen_fn | acc}
    }

    fold(%{}, fold_step, projects)
}

let endpoints = merge_maps(endpoints, detail_endpoints)

let global_state = %{
    "header" => read_file("templates/header.html"),
    "footer" => read_file("templates/footer.html"),
    "ghicon" => read_file("templates/gh-icon.svg"),
    "liicon" => read_file("templates/li-icon.svg"),
    "linkicon" => read_file("templates/link-icon.svg")
}

gen_site("https://mkhan45.github.io/rustscript_site/", endpoints, "docs", global_state)
