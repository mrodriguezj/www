import { consumirAPI } from './api.js';

export async function cargarPagosVencidos() {
  const data = await consumirAPI('pagos_vencidos');
  if (!data) return;

  const tbody = document.getElementById('tablaPagosVencidosBody');
  tbody.innerHTML = '';

  data.forEach(item => {
    const fila = document.createElement('tr');
    fila.innerHTML = `
      <td class="px-4 py-3">${item.cliente}</td>
      <td class="px-4 py-3">${item.propiedad}</td>
      <td class="px-4 py-3">${item.numero_pago}</td>
      <td class="px-4 py-3">${item.fecha_vencimiento}</td>
      <td class="px-4 py-3">$${parseFloat(item.monto_restante).toLocaleString()}</td>
      <td class="px-4 py-3">${item.dias_mora} días</td>
      <td class="px-4 py-3">${item.estatus_pago}</td>
    `;
    tbody.appendChild(fila);
  });
}
