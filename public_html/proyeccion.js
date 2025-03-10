async function consultarProyeccion() {
    const fecha_inicio = document.getElementById('fecha_inicio').value;
    const fecha_fin = document.getElementById('fecha_fin').value;
    const fecha_consulta = document.getElementById('fecha_consulta').value;
  
    if (!fecha_inicio || !fecha_fin) {
      alert('Debes ingresar las fechas de inicio y fin.');
      return;
    }
  
    try {
      const response = await fetch('http://localhost/api/index.php?endpoint=proyeccion_pagos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fecha_inicio, fecha_fin, fecha_consulta })
      });
  
      const data = await response.json();
  
      if (data.error) {
        alert(data.error);
        return;
      }
  
      mostrarResumen(data.resultados);
      llenarTablaPagos(data.resultados);
  
    } catch (error) {
      console.error('Error al consultar la proyección:', error);
    }
  }
  
  function mostrarResumen(pagos) {
    let proyectado = 0, cobrado = 0, pendiente = 0, vencido = 0;
  
    pagos.forEach(p => {
      proyectado += parseFloat(p.monto_programado);
  
      if (p.estatus_pago === 'Pagado') {
        cobrado += parseFloat(p.monto_programado);
      } else if (p.estatus_pago === 'Pendiente') {
        pendiente += parseFloat(p.monto_restante);
      } else if (p.estatus_pago === 'Vencido') {
        vencido += parseFloat(p.monto_restante);
      }
    });
  
    document.getElementById('monto_proyectado').innerText = `$${proyectado.toFixed(2)}`;
    document.getElementById('monto_cobrado').innerText = `$${cobrado.toFixed(2)}`;
    document.getElementById('monto_pendiente').innerText = `$${pendiente.toFixed(2)}`;
    document.getElementById('monto_vencido').innerText = `$${vencido.toFixed(2)}`;
  }
  
  function llenarTablaPagos(pagos) {
    const cuerpoTabla = document.getElementById('tabla_pagos');
    cuerpoTabla.innerHTML = '';
  
    pagos.forEach(p => {
      const row = `
        <tr class="border-b hover:bg-gray-50">
          <td class="px-4 py-2">${p.cliente_nombre}</td>
          <td class="px-4 py-2">${p.calle} - Etapa ${p.etapa}</td>
          <td class="px-4 py-2">${p.fecha_vencimiento}</td>
          <td class="px-4 py-2">$${parseFloat(p.monto_programado).toFixed(2)}</td>
          <td class="px-4 py-2">${p.estatus_pago}</td>
          <td class="px-4 py-2">${p.dias_atraso}</td>
          <td class="px-4 py-2">
            <button onclick="verDetallePago(${p.id_calendario})" class="text-blue-600 hover:underline">Ver Detalle</button>
          </td>
        </tr>
      `;
      cuerpoTabla.innerHTML += row;
    });
  }
  
  async function verDetallePago(id_calendario) {
    try {
      // Aquí debes hacer el llamado al endpoint que trae el detalle del pago realizado, 
      // pero como estamos pasando id_calendario, puedes hacer un paso extra para obtener el pago.
  
      const response = await fetch('http://localhost/api/index.php?endpoint=detalle_pago', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id_pago: id_calendario }) // Debe ser el ID del pago, no del calendario. Adapta según sea necesario.
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
  