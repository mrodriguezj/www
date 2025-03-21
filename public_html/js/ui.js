export function abrirOffCanvas(titulo) {
    document.getElementById('tituloOffCanvas').textContent = titulo;
    document.getElementById('offCanvasOverlay').classList.remove('hidden');
    document.getElementById('offCanvasDetalles').classList.remove('translate-x-full');
    document.getElementById('offCanvasDetalles').classList.add('translate-x-0');
  }
  
  export function cerrarOffCanvas() {
    document.getElementById('offCanvasOverlay').classList.add('hidden');
    document.getElementById('offCanvasDetalles').classList.add('translate-x-full');
    document.getElementById('offCanvasDetalles').classList.remove('translate-x-0');
  }
  