import { cargarResumenHistorico, cargarProyeccionPeriodo } from './kpis.js';
import { iniciarFiltros } from './filtros.js';
import { cargarEstadoPropiedades, abrirDetallesPropiedades } from './propiedades.js';
import { cargarPagosVencidos } from './pagos.js';
import { cerrarOffCanvas } from './ui.js';

document.addEventListener("DOMContentLoaded", () => {
  // Cargar los datos iniciales
  cargarResumenHistorico();
  //cargarProyeccionPeriodo(new Date().getMonth() + 1, new Date().getFullYear()); //CARGA DATOS INICIALES
  cargarEstadoPropiedades();
  cargarPagosVencidos();

  // Inicializamos el manejo del modal de filtros
  iniciarFiltros();

  // Eventos de click para abrir los detalles de propiedades (off-canvas)
  document.getElementById('propiedadesVendidas').addEventListener('click', () => {
    abrirDetallesPropiedades('vendidas');
  });

  document.getElementById('propiedadesDisponibles').addEventListener('click', () => {
    abrirDetallesPropiedades('disponibles');
  });

  document.getElementById('propiedadesReservadas').addEventListener('click', () => {
    abrirDetallesPropiedades('reservadas');
  });

  // Cerrar el off-canvas desde los botones y overlay
  document.getElementById('cerrarOffCanvas').addEventListener('click', cerrarOffCanvas);
  document.getElementById('cerrarOffCanvasFooter').addEventListener('click', cerrarOffCanvas);
  document.getElementById('offCanvasOverlay').addEventListener('click', cerrarOffCanvas);
});
