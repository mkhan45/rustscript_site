let endpoints = %{
    "index.html" => fn(gen_state) => {
	let state = "assets/resume.toml" |> read_file |> parse_toml
	template_file_string("templates/resume.html", state)
    }
}

gen_site(endpoints, "out", %{})
