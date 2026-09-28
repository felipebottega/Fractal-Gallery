# Fractal Gallery

<h1>About</h1>
<p><strong>Fractal Gallery</strong> is a small interactive 2D game dedicated to the geometry of fractals. Walk through the exhibition, inspect several classic fractals rendered in real time, and jump into a painting to explore it directly.
</p>
<p>The gallery currently includes the <strong>Mandelbrot Set, Julia Set, Burning Ship, Tricorn, Newton fractal, Celtic Mandelbrot</strong>, and a <strong>custom polynomial fractal</strong>. These are not pre-rendered images, the fractals are calculated live on the GPU using Godot shaders.&nbsp;</p>
<p><br></p>

<p align="center">
  <img width="500" src="https://github.com/user-attachments/assets/cbf00603-78cf-4865-8aa5-ad92cd0ca47d" />
</p>

<h1>Play</h1>
<p>You can play <strong>Fractal Gallery</strong> directly on itch.io:</p>
<p><a href="https://integral-pixels.itch.io/fractal-gallery"><strong>https://integral-pixels.itch.io/fractal-gallery</strong></a></p>
<p><br></p>

<h1>Controls</h1>
<p>In the gallery, use <strong>A / D</strong> or the <strong>Left / Right Arrow keys</strong> to walk and <strong>Space</strong> to jump. Jump into one of the paintings to enter its fractal.
</p>
<p>Inside a fractal:
</p>
<ul><li><strong>Mouse wheel:</strong>&nbsp;zoom in and out, centered on the mouse position
</li><li><strong>Left mouse button + drag:&nbsp;</strong>move through the complex plane
</li><li><strong>Esc</strong> or <strong>Quit:&nbsp;</strong>return to the gallery
</li><li><strong>Click on the "?"</strong>&nbsp;to obtain information about the current fractal and its parameters
</li></ul>
<p>Each exhibit also has its own real-time controls. Depending on the fractal, you can change the iteration limit, coloring, Julia parameter c, convergence precision, polynomial coefficients, or other mathematical parameters used to generate the image.</p>
<p><br></p>

<p align="center">
  <img width="500" src="https://github.com/user-attachments/assets/2429c933-653a-4fd3-a0c5-47bdb50e4fd5" />
</p>

<h1>Custom Polynomial Fractal</h1>
<p>The final exhibit lets you build your own escape-time polynomial fractal using:
</p>
<p><strong>zₙ₊₁ = a₆zₙ⁶ + a₅zₙ⁵ + a₄zₙ⁴ + a₃zₙ³ + a₂zₙ² + a₁zₙ + c, with z₀ = 0</strong>
</p>
<p>The six coefficients a₁, ..., a₆ are real and can be adjusted independently.
</p>
<p>The default values are&nbsp;<strong>a₂ = 1&nbsp;</strong>and&nbsp;<strong>a₁ = a₃ = a₄ = a₅ = a₆ = 0,&nbsp;</strong>which gives the classic Mandelbrot iteration&nbsp;<strong>zₙ₊₁ = zₙ² + c</strong></p>
<p>From there, the coefficients can be changed to deform the familiar Mandelbrot set or generate different polynomial families.
</p>
<p>Because the growth rate changes with the degree of the polynomial, the escape radius is calculated dynamically from the highest active degree instead of using the standard Mandelbrot escape radius blindly.</p>
<p><br></p>

<h1>How it works</h1>
<p>Most of the exhibits are <strong>escape-time fractals</strong>. For every pixel, the shader maps the screen position to a complex number and repeatedly applies a mathematical transformation. The number of iterations required for the orbit to escape determines the resulting color. Points that do not escape within the selected iteration limit are treated as belonging to the set.
</p>
<p>The Newton exhibit works differently. Each pixel is used as the initial value for <strong>Newton's method</strong>, and the resulting colors represent the different basins of attraction of the polynomial's roots.</p>
<p><br></p>

<p align="center">
  <img width="500" src="https://github.com/user-attachments/assets/7d396e77-171f-41ca-83a9-1729afe64c5a" />
</p>

<h1>A note about deep zoom</h1>
<p>This is an interactive real-time visualization, <strong>not an arbitrary-precision fractal renderer</strong>.
</p>
<p>The shaders use standard GPU floating-point arithmetic, which has finite precision. As the view becomes extremely small, neighboring pixels eventually correspond to numerical values that the GPU can no longer distinguish reliably.
</p>
<p>For that reason, the game deliberately stops further zooming at approximately&nbsp;<strong>10⁻⁶.&nbsp;</strong>The goal of <strong>Fractal Gallery</strong> is not to reach record-breaking magnifications, but to provide a simple interactive way to <strong>walk through, manipulate, and explore some of the structures hidden in the complex plane</strong>.<strong><br></strong></p>

