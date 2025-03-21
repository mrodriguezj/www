document.addEventListener("DOMContentLoaded", () => {
    // Inicializamos los datos al cargar la página
    cargarResumenHistorico();
    cargarEstadoPropiedades();
    cargarPagosVencidos();
  
    // Escuchamos el botón de filtros (mes y año)
    document.getElementById('btnAplicarFiltros').addEventListener('click', () => {
      const mes = document.getElementById('mes').value;
      const anio = document.getElementById('anio').value;
  
      cargarProyeccionPeriodo(mes, anio);
    });
  });
  
  /**
   * Función global para consumir endpoints
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
  
    document.getElementById("propiedadesVendidas").textContent = data.vendidas;
    document.getElementById("propiedadesDisponibles").textContent = data.disponibles;
    document.getElementById("propiedadesReservadas").textContent = data.reservadas;
  }
  
  /**
   * Sección 4: Detalle de Pagos Vencidos
   */
  async function cargarPagosVencidos() {
    const data = await consumirAPI('pagos_vencidos');
    if (!data) return;
  
    const tbody = document.getElementById('tablaPagosVencidosBody');
    tbody.innerHTML = ''; // Limpia la tabla antes de renderizar nuevos datos
  
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
  