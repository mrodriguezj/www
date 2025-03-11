let offsetActual = 0;
const registrosPorCarga = 20;
let cargando = false;
let datosCargados = [];

async function consultarProyeccion() {
  offsetActual = 0;
  datosCargados = [];

  await cargarTotalesProyeccion();
  await cargarPagosScroll(true); // primera carga
}

async function cargarTotalesProyeccion() {
  const filtros = obtenerFiltros();

  try {
    const response = await fetch('http://localhost/api/index.php?endpoint=proyeccion_pagos_totales', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(filtros)
    });

    const data = await response.json();

    if (data.error) {
      alert(data.error);
      return;
    }

    mostrarTotales(data.resumen);

  } catch (error) {
    console.error('Error al cargar totales:', error);
  }
}

async function cargarPagosScroll(primeraCarga = false) {
  if (cargando) return;
  cargando = true;

  const filtros = obtenerFiltros();
  filtros.limit = registrosPorCarga;
  filtros.offset = offsetActual;

  try {
    const response = await fetch('http://localhost/api/index.php?endpoint=proyeccion_pagos_detalles', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(filtros)
    });

    const data = await response.json();

    if (data.error) {
      alert(data.error);
      cargando = false;
      return;
    }

    datosCargados = [...datosCargados, ...data.resultados];
    renderizarPagos(data.resultados, primeraCarga);

    offsetActual += registrosPorCarga;
    cargando = false;

  } catch (error) {
    console.error('Error al cargar pagos:', error);
    cargando = false;
  }
}

function obtenerFiltros() {
  return {
    fecha_inicio: document.getElementById('fecha_inicio').value,
    fecha_fin: document.getElementById('fecha_fin').value,
    fecha_consulta: document.getElementById('fecha_consulta').value,
    estado_pago: document.getElementById('filtro_estado').value,
    cliente_nombre: document.getElementById('filtro_cliente').value
  };
}

function mostrarTotales(totales) {
  document.getElementById('monto_proyectado').innerText = `$${parseFloat(totales.total_programado || 0).toFixed(2)}`;
  document.getElementById('monto_cobrado').innerText = `$${parseFloat(totales.total_cobrado || 0).toFixed(2)}`;
  document.getElementById('monto_pendiente').innerText = `$${parseFloat(totales.total_pendiente || 0).toFixed(2)}`;
  document.getElementById('monto_vencido').innerText = `$${parseFloat(totales.total_vencido || 0).toFixed(2)}`;
}

function renderizarPagos(pagos, primeraCarga = false) {
  const contenedor = document.getElementById('contenedor_pagos');

  if (primeraCarga) {
    contenedor.innerHTML = '';
  }

  if (!pagos || pagos.length === 0) {
    if (primeraCarga) {
      contenedor.innerHTML = `<p class="text-center py-4 text-gray-500">No se encontraron registros.</p>`;
    }
    return;
  }

  pagos.forEach(p => {
    const div = document.createElement('div');
    div.classList = 'border-b py-2 flex justify-between items-center hover:bg-gray-50 cursor-pointer';
    div.innerHTML = `
      <div>
        <p><strong>${p.cliente_nombre}</strong> - Lote ID: ${p.id_lote}</p>
        <p class="text-sm text-gray-500">Vence: ${p.fecha_vencimiento} | Estado: ${p.estatus_pago} | Días atraso: ${p.dias_atraso}</p>
      </div>
      <div class="font-bold">$${parseFloat(p.monto_programado).toFixed(2)}</div>
    `;
    div.onclick = () => verDetallePago(p.id_calendario);

    contenedor.appendChild(div);
  });
}

function inicializarScrollInfinito() {
  const contenedor = document.getElementById('contenedor_pagos');

  contenedor.addEventListener('scroll', () => {
    if (contenedor.scrollTop + contenedor.clientHeight >= contenedor.scrollHeight - 50) {
      cargarPagosScroll(false);
    }
  });
}

async function verDetallePago(id_calendario) {
  try {
    const response = await fetch('http://localhost/api/index.php?endpoint=detalle_pago', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id_pago: id_calendario })
    });

    const data = await response.json();

    if (data.error) {
      alert(data.error);
      return;
    }

    mostrarModalDetalle(data);

  } catch (error) {
    console.error('Error al obtener el detalle del pago:', error);
  }
}

function mostrarModalDetalle(data) {
  const contenedor = document.getElementById('modal_contenido');
  const pago = data.pago && data.pago[0];
  const relaciones = data.relaciones || [];

  if (!pago) {
    contenedor.innerHTML = '<p>No se encontró información del pago.</p>';
    abrirModal();
    return;
  }

  let html = `
    <div class="mb-4">
      <p><strong>Cliente:</strong> ${pago.cliente_nombre}</p>
      <p><strong>Lote:</strong> ${pago.calle} - Etapa ${pago.etapa}</p>
      <p><strong>Fecha Pago:</strong> ${pago.fecha_pago}</p>
      <p><strong>Monto Pagado:</strong> $${parseFloat(pago.monto_pagado).toFixed(2)}</p>
      <p><strong>Método de Pago:</strong> ${pago.metodo_pago}</p>
      <p><strong>Referencia:</strong> ${pago.referencia_pago || 'N/A'}</p>
    </div>
    <h3 class="text-lg font-semibold mb-2">Relaciones de Pago</h3>
    <ul class="list-disc list-inside">
  `;

  relaciones.forEach(r => {
    html += `<li>${r.categoria_pago} | Vence: ${r.fecha_vencimiento} | Monto Aplicado: $${parseFloat(r.monto_asignado).toFixed(2)}</li>`;
  });

  html += '</ul>';

  contenedor.innerHTML = html;
  abrirModal();
}

function abrirModal() {
  document.getElementById('modal').classList.remove('hidden');
  document.getElementById('modal').classList.add('flex');
}

function cerrarModal() {
  document.getElementById('modal').classList.add('hidden');
}

window.addEventListener('DOMContentLoaded', () => {
  inicializarScrollInfinito();
});


function exportarPagosCSV() {
  if (!datosCargados || datosCargados.length === 0) {
    alert('No hay datos para exportar.');
    return;
  }

  // Cabeceras para el CSV
  const headers = [
    'ID Calendario',
    'ID Lote',
    'Cliente',
    'Descripción Lote',
    'Fecha Vencimiento',
    'Monto Programado',
    'Monto Restante',
    'Categoría Pago',
    'Estatus Pago',
    'Días Atraso'
  ];

  // Cuerpo de datos
  const rows = datosCargados.map(p => [
    p.id_calendario,
    p.id_lote,
    p.cliente_nombre,
    p.descripcion_lote,
    p.fecha_vencimiento,
    parseFloat(p.monto_programado).toFixed(2),
    parseFloat(p.monto_restante).toFixed(2),
    p.categoria_pago,
    p.estatus_pago,
    p.dias_atraso
  ]);

  // Generar el contenido del CSV
  let csvContent = "data:text/csv;charset=utf-8," 
    + headers.join(",") + "\n"
    + rows.map(e => e.join(",")).join("\n");

  // Crear y disparar la descarga
  const encodedUri = encodeURI(csvContent);
  const link = document.createElement("a");
  link.setAttribute("href", encodedUri);

  const fechaExportacion = new Date().toISOString().slice(0, 10);
  link.setAttribute("download", `proyeccion_pagos_${fechaExportacion}.csv`);

  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
