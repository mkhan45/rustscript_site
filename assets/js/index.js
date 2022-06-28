// hack
//document.querySelector(".resume .skills").innerHTML = 
//	document.querySelector(".resume .skills").innerHTML.trimEnd().slice(0, -1)

const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
if (screen.width >= 768 && !mediaQuery.matches) {
	const pixiApp = new PIXI.Application({ 
	    view: document.querySelector("#bg"),
	    antialias: true,
	    backgroundColor: 0x6192f4,
	    autoResize: true,
	    resolution: devicePixelRatio,
	});

	function resize() {
	    pixiApp.renderer.resize(window.innerWidth, window.innerHeight);
	}
	window.addEventListener('resize', resize);
	resize();

	// set coordinate system to start from center of screen
	pixiApp.stage.x = pixiApp.screen.width / 2;
	pixiApp.stage.y = pixiApp.screen.height / 2;

	const top_edge = -pixiApp.screen.height / 2;
	const left_edge = -pixiApp.screen.width / 2;

	const obstructingElements = [...document.querySelectorAll(".opaque")];

	// initialize circles into particle container
	const radius = 2.75;
	const offset = radius * 30.0;
	const num_rows = pixiApp.screen.height / offset;
	const num_cols = pixiApp.screen.width / offset;

	let container = new PIXI.ParticleContainer();
	let circle_geom = new PIXI.Graphics().beginFill(0xffffff).drawCircle(0, 0, radius).endFill();
	let circle_texture = pixiApp.renderer.generateTexture(circle_geom);
	let circles = [];

	for (let i = 0; i < num_cols; i += 1) {
	    for (let j = 0; j < num_rows; j += 1) {
		const x = left_edge + i * offset;
		const y = top_edge + j * offset;

		const obstructed = obstructingElements.some(e => {
		    let bounding_box = e.getBoundingClientRect();
		    bounding_box.x += left_edge;
		    bounding_box.y += top_edge;
		
		    return x > bounding_box.x - offset && x < bounding_box.x + bounding_box.width + offset
			&& y > bounding_box.y && y < bounding_box.y + bounding_box.height;
		});

		if (!obstructed) {
		    let sprite = new PIXI.Sprite(circle_texture);
		    sprite.x = x;
		    sprite.y = y;
		    circles.push({sprite: sprite, vx: 0, vy: 0, start_x: x, start_y: y, mouse_interact: false});
		    container.addChild(sprite);
		}
	    }
	}
	pixiApp.stage.addChild(container);

	let line_geom = new PIXI.Graphics();
	pixiApp.stage.addChild(line_geom);

	// get mouse position
	let mouse_x = 0;
	let mouse_y = 0;
	document.onmousemove = e => {
	    mouse_x = e.clientX + left_edge;
	    mouse_y = e.clientY + top_edge;
	};

	pixiApp.ticker.add(delta => {
	    // integration and damping
	    circles.forEach(circle => {
		circle.sprite.x += circle.vx;
		circle.sprite.y += circle.vy;

		circle.vx *= 0.8;
		circle.vy *= 0.8;
	    });

	    // mouse gravity
	    circles.forEach(circle => {
		let x_rad = (circle.sprite.x - mouse_x);
		let y_rad = (circle.sprite.y - mouse_y);

		let dist_sqr = x_rad * x_rad + y_rad * y_rad;

		// if the distance is too far don't compute for performance
		
		// there's a little bit of padding around actually changing the flag 
		// to make the lines look better
		circle.mouse_interact = !(dist_sqr > 11000);
		if (dist_sqr > 10000) return;


		let grav = Math.min(500 / Math.max(x_rad * x_rad + y_rad * y_rad, 1), 10);

		circle.vx += grav * Math.sign(x_rad) * delta;
		circle.vy += grav * Math.sign(y_rad) * delta;
	    });

	    // circle startpoint gravity
	    circles.forEach(circle => {
		if (circle.mouse_interact) return;

		let x_rad = -(circle.sprite.x - circle.start_x);
		let y_rad = -(circle.sprite.y - circle.start_y);

		let dist_sqr = x_rad * x_rad + y_rad * y_rad;

		// ignore if the circle is near enough to the start point
		if (dist_sqr < 10) return;

		let grav = dist_sqr / 10000 + 0.1;

		circle.vx += grav * Math.sign(x_rad) * delta;
		circle.vy += grav * Math.sign(y_rad) * delta;
	    });

	    // render lines
	    line_geom.clear();
	    circles.forEach(circle => {
		if (circle.mouse_interact) {
		    let x_rad = (circle.sprite.x - mouse_x);
		    let y_rad = (circle.sprite.y - mouse_y);
		    let rad_sqr = x_rad * x_rad + y_rad * y_rad;

		    line_geom
			.lineStyle(Math.min(5000 / Math.max(rad_sqr, 1), 5), 0xffffff)
			.moveTo(mouse_x, mouse_y)
			.lineTo(circle.sprite.x + radius, circle.sprite.y + radius);
		}
	    });
	});
}

