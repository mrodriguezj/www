import { consumirAPI } from './api.js';

export async function cargarEstadoPropiedades() {
  const data = await consumirAPI('estado_propiedades');
  if (!data) return;

  document.getElementById("valorPropiedadesVendidas").textContent = data.vendidas;
  document.getElementById("valorPropiedadesDisponibles").textContent = data.disponibles;
  document.getElementById("valorPropiedadesReservadas").textContent = data.reservadas;
}

export async function abrirDetallesPropiedades(categoria) {
  const titulos = {
    vendidas: 'Detalles de Propiedades Vendidas',
    disponibles: 'Detalles de Propiedades Disponibles',
    reservadas: 'Detalles de Propiedades Reservadas'
  };

  abrirOffCanvas(titulos[categoria] || 'Detalles de Propiedades');

  const data = await consumirAPI(`detalles_propiedades`, `&categoria=${categoria}`);
  const tbody = document.getElementById('tablaDetallesOffCanvas');
  tbody.innerHTML = '';

  if (!data || data.length === 0) {
    tbody.innerHTML = `<tr><td colspan="3" class="text-center py-4">Sin registros disponibles</td></tr>`;
    return;
  }

  data.forEach(item => {
    const fila = document.createElement('tr');
    fila.innerHTML = `
      <td class="px-4 py-3">${item.lote}</td>
      <td class="px-4 py-3">${item.fecha_venta || 'N/A'}</td>
      <td class="px-4 py-3">${item.cliente || 'N/A'}</td>
    `;
    tbody.appendChild(fila);
  });
}

export function abrirOffCanvas(titulo) {
  const offCanvas = document.getElementById('offCanvasDetalles');
  const overlay = document.getElementById('offCanvasOverlay');

  document.getElementById('tituloOffCanvas').textContent = titulo;
  overlay.classList.remove('hidden');
  offCanvas.classList.remove('translate-x-full');
  offCanvas.classList.add('translate-x-0');
}

export function cerrarOffCanvas() {
  const offCanvas = document.getElementById('offCanvasDetalles');
  const overlay = document.getElementById('offCanvasOverlay');

  offCanvas.classList.add('translate-x-full');
  offCanvas.classList.remove('translate-x-0');
  overlay.classList.add('hidden');
}
