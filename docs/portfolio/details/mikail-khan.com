<!DOCTYPE html>
<html>
<head>
  <title>mikail-khan.com</title>
  <link rel="stylesheet" href="css/base.css">
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<script src="js/pixi.min.js"></script>

</head>
<body>
  <canvas id="bg"></canvas>
  <main>
    <div class="detail-container flex-parent">
      <div class="header detail-header opaque">
          <h1>mikail-khan.com</h1>
        <div class="detail-link">
            <a href="https://calcula.tech">https://github.com/mkhan45/mikail-khan.com</a>
        </div>
        <nav class="body-center smallmenu">
          <div>
          <a class="linkButton" href="index.html">Home</a>
          </div>
          <div>
          <a class="linkButton" href="portfolio.html">Portfolio</a>
          </div>
        </nav>
      </div>
      <div class="body-center detail-body">
        <div class="detail-card opaque">
        <div class="detail-img-container"><img src="https://mikail-khan.com/img/site.png" class="detail-img"></div>
            
My personal website.
<ul>
    <li>Written in Haskell using the Servant Web framework</li>
    <li>Uses the Blaze-HTML DSL for markup</li>
    <li>Includes a template caching system to decrease server load</li>
    <li>Reads resume/portfolio details from TOML files to generate pages</li>

        </div>
      </div>
    </div>
  </main>
  <script src="js/index.js"></script>

</body>
</html>
