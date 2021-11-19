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
	let state = "assets/portfolio.toml" 
	    |> read_file 
	    |> parse_toml 
	    |> merge_maps(_, gen_state)
	template_file_string("templates/portfolio.html", state)
    },
    ("css/base.css", "css") => fn(_) => {
	read_file("assets/css/base.css")
    },
    ("js/pixi.min.js", "pixijs") => fn(_) => {
	read_file("assets/js/pixi.min.js")
    },
    ("js/index.js", "indexjs") => fn(_) => {
	read_file("assets/js/index.js")
    }
}

let global_state = %{
    "header" => read_file("templates/header.html"),
    "footer" => read_file("templates/footer.html"),
    "ghicon" => read_file("templates/gh-icon.svg"),
    "liicon" => read_file("templates/li-icon.svg"),
    "linkicon" => read_file("templates/link-icon.svg")
}
gen_site(endpoints, "docs", global_state)
