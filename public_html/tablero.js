document.addEventListener("DOMContentLoaded", () => {

  // Carga inicial de KPIs
  cargarResumenHistorico();
  cargarEstadoPropiedades();
  cargarPagosVencidos();

  // Filtros para proyección del periodo
// Botón de abrir filtro
document.getElementById('btnAbrirFiltro').addEventListener('click', () => {
  const modal = document.getElementById('modalFiltro');
  modal.classList.remove('hidden');
  modal.classList.add('flex');
});

// Botón de cerrar filtro
document.getElementById('btnCerrarFiltro').addEventListener('click', () => {
  const modal = document.getElementById('modalFiltro');
  modal.classList.add('hidden');
  modal.classList.remove('flex');
});

// Botón de aplicar filtros (hace fetch)
document.getElementById('btnAplicarFiltros').addEventListener('click', () => {
  const mes = document.getElementById('mes').value;
  const anio = document.getElementById('anio').value;

  console.log(`Aplicando filtros: Mes ${mes}, Año ${anio}`);

  cargarProyeccionPeriodo(mes, anio);

  const modal = document.getElementById('modalFiltro');
  modal.classList.add('hidden');
  modal.classList.remove('flex');
});

  // Eventos de click para abrir los detalles por tipo de propiedad
  document.getElementById('propiedadesVendidas').addEventListener('click', () => {
    abrirDetallesPropiedades('vendidas');
  });
  document.getElementById('propiedadesDisponibles').addEventListener('click', () => {
    abrirDetallesPropiedades('disponibles');
  });
  document.getElementById('propiedadesReservadas').addEventListener('click', () => {
    abrirDetallesPropiedades('reservadas');
  });

  // Cierre del off-canvas desde los botones
  document.getElementById('cerrarOffCanvas').addEventListener('click', cerrarOffCanvas);
  document.getElementById('cerrarOffCanvasFooter').addEventListener('click', cerrarOffCanvas);

  // Cierre del off-canvas desde el overlay
  document.getElementById('offCanvasOverlay').addEventListener('click', cerrarOffCanvas);
});

/**
 * Función global para consumir endpoints de la API
 */
async function consumirAPI(endpoint, params = '') {
  const url = `/api/index.php?endpoint=${endpoint}${params}`;
  try {
    const respuesta = await fetch(url);
    if (!respuesta.ok) throw new Error(`HTTP error! Status: ${respuesta.status}`);

    const data = await respuesta.json();
    if (!data.success) {
      console.error(`Error en endpoint: ${endpoint}`, data.message);
      return null;
    }

    return data.data;

  } catch (error) {
    console.error(`Error de conexión en endpoint: ${endpoint}`, error);
    return null;
  }
}

/**
 * Sección 1: Resumen Histórico General
 */
async function cargarResumenHistorico() {
  const data = await consumirAPI('resumen_historico');
  if (!data) return;

  document.getElementById("totalCobradoHistorico").textContent = `$${parseFloat(data.total_cobrado).toLocaleString()}`;
  document.getElementById("carteraVencidaHistorico").textContent = `$${parseFloat(data.cartera_vencida).toLocaleString()}`;
  document.getElementById("porcentajeRecuperacionHistorico").textContent = `${data.porcentaje_recuperacion}%`;
}

/**
 * Sección 2: Proyección del Periodo
 */
async function cargarProyeccionPeriodo(mes, anio) {
  const data = await consumirAPI(`proyeccion_periodo`, `&mes=${mes}&anio=${anio}`);
  if (!data) return;

  document.getElementById("proyeccionCobroPeriodo").textContent = `$${parseFloat(data.proyeccion_cobro).toLocaleString()}`;
  document.getElementById("carteraVencidaPeriodo").textContent = `$${parseFloat(data.cartera_vencida_periodo).toLocaleString()}`;
  document.getElementById("porcentajeRecuperacionPeriodo").textContent = `${data.porcentaje_recuperacion_periodo}%`;
}

/**
 * Sección 3: Estado de Propiedades
 */
async function cargarEstadoPropiedades() {
  const data = await consumirAPI('estado_propiedades');
  if (!data) return;

  document.getElementById("valorPropiedadesVendidas").textContent = data.vendidas;
  document.getElementById("valorPropiedadesDisponibles").textContent = data.disponibles;
  document.getElementById("valorPropiedadesReservadas").textContent = data.reservadas;
}

/**
 * Sección 4: Detalle de Pagos Vencidos
 */
async function cargarPagosVencidos() {
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
      <td class="px-4 py-3">
        <span class="${obtenerClaseEstatus(item.estatus_pago)}">${item.estatus_pago}</span>
      </td>
    `;

    tbody.appendChild(fila);
  });
}

/**
 * Función para determinar el color del estatus de pagos vencidos
 */
function obtenerClaseEstatus(estatus) {
  switch (estatus) {
    case 'Vencido':
      return 'inline-block px-2 py-1 bg-red-100 text-red-800 text-xs rounded-full';
    case 'Pagado':
      return 'inline-block px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full';
    case 'Pendiente':
      return 'inline-block px-2 py-1 bg-yellow-100 text-yellow-800 text-xs rounded-full';
    default:
      return '';
  }
}

/**
 * Abre el off-canvas y carga los detalles de propiedades
 */
async function abrirDetallesPropiedades(categoria) {
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

/**
 * Abre el panel off-canvas y muestra el overlay
 */
function abrirOffCanvas(titulo) {
  const offCanvas = document.getElementById('offCanvasDetalles');
  const overlay = document.getElementById('offCanvasOverlay');

  document.getElementById('tituloOffCanvas').textContent = titulo;

  overlay.classList.remove('hidden');
  offCanvas.classList.remove('translate-x-full');
  offCanvas.classList.add('translate-x-0');
}

/**
 * Cierra el panel off-canvas y oculta el overlay
 */
function cerrarOffCanvas() {
  const offCanvas = document.getElementById('offCanvasDetalles');
  const overlay = document.getElementById('offCanvasOverlay');

  offCanvas.classList.add('translate-x-full');
  offCanvas.classList.remove('translate-x-0');
  overlay.classList.add('hidden');
}
