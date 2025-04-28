let currentPage = 1;
const pageSize = 20; // cantidad de registros por página

async function cargarPagos() {
    const fecha_inicio = document.getElementById('fecha_inicio').value;
    const fecha_fin = document.getElementById('fecha_fin').value;
    const categoria_pago = document.getElementById('categoria_pago').value;
    const metodo_pago = document.getElementById('metodo_pago').value;

    const loader = document.getElementById('loader');
    const mensajeInicial = document.getElementById('mensaje-inicial');

    loader.style.display = 'block';
    mensajeInicial.style.display = 'none';

    let offset = (currentPage - 1) * pageSize;

    let url = '/api/index.php?endpoint=cobranza_efectuada';

    const params = new URLSearchParams();
    if (fecha_inicio) params.append('fecha_inicio', fecha_inicio);
    if (fecha_fin) params.append('fecha_fin', fecha_fin);
    if (categoria_pago) params.append('categoria_pago', categoria_pago);
    if (metodo_pago) params.append('metodo_pago', metodo_pago);
    params.append('limit', pageSize);
    params.append('offset', offset);

    if (params.toString()) {
        url += '&' + params.toString();
    }

    try {
        const response = await fetch(url);
        const data = await response.json();

        const tbody = document.querySelector("#tabla-pagos tbody");
        let html = "";

        if (data.length === 0) {
            html = `<tr><td colspan="5">No se encontraron resultados.</td></tr>`;
        } else {
            data.forEach(pago => {
                html += `
                    <tr>
                        <td>${pago.id_lote}</td> <!-- 👈 Nueva celda -->    
                        <td>${pago.nombre_cliente}</td>
                        <td>${pago.fecha_pago}</td>
                        <td>$${parseFloat(pago.monto_pagado).toLocaleString()}</td>
                        <td>${pago.categoria_pago}</td>
                        <td>${pago.metodo_pago}</td>
                    </tr>
                `;
            });
        }
        tbody.innerHTML = html;

    } catch (error) {
        console.error('Error al cargar pagos:', error);
        alert('Ocurrió un error al obtener los datos.');
    } finally {
        loader.style.display = 'none';
    }
}

function siguientePagina() {
    currentPage++;
    cargarPagos();
}

function paginaAnterior() {
    if (currentPage > 1) {
        currentPage--;
        cargarPagos();
    }
}
