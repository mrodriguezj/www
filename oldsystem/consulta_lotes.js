document.getElementById("buscarPagos").addEventListener("click", async function () {
    let idLote = document.getElementById("id_lote").value;

    if (!idLote || idLote <= 0) {
        showModal("Error", "Ingrese un ID de lote válido.");
        return;
    }

    try {
        let response = await fetch(`/oldsystem/consulta_pagos_lotes.php?id_lote=${idLote}`);
        let data = await response.json();

        let tablaPagos = document.getElementById("tablaPagos");
        tablaPagos.innerHTML = "";

        if (data.error) {
            showModal("Error", data.error);
            tablaPagos.innerHTML = '<tr><td colspan="7" class="p-4 text-gray-500">No hay datos</td></tr>';
        } else {
            // Ordenar datos por fecha de pago en orden cronológico (ascendente)
            data.sort((a, b) => new Date(a.fecha_pago) - new Date(b.fecha_pago));

            data.forEach(pago => {
                let fechaFormateada = formatearFecha(pago.fecha_pago);
                let montoFormateado = formatearMoneda(pago.monto);

                let row = `
                    <tr class="hover:bg-gray-100">
                        <td class="p-3 border">${pago.id_pago}</td>
                        <td class="p-3 border">${pago.concepto}</td>
                        <td class="p-3 border text-green-600 font-bold">${montoFormateado}</td>
                        <td class="p-3 border">${fechaFormateada}</td>
                        <td class="p-3 border">${pago.metodo_pago}</td>
                        <td class="p-3 border">${pago.banco}</td>
                        <td class="p-3 border">${pago.periodo_pago}</td>
                    </tr>
                `;
                tablaPagos.innerHTML += row;
            });
        }
    } catch (error) {
        showModal("Error", "Error en la consulta: " + error.message);
    }
});

// 🔹 Función para formatear fecha en "DD-MM-YYYY"
function formatearFecha(fechaISO) {
    let fecha = new Date(fechaISO);
    let dia = fecha.getDate().toString().padStart(2, '0');
    let mes = (fecha.getMonth() + 1).toString().padStart(2, '0');
    let anio = fecha.getFullYear();
    return `${dia}-${mes}-${anio}`;
}

// 🔹 Función para formatear monto en moneda (Ej: $1,500.00)
function formatearMoneda(monto) {
    return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(monto);
}

function showModal(title, message) {
    document.getElementById("modal-title").innerText = title;
    document.getElementById("modal-message").innerText = message;
    document.getElementById("modal").classList.remove("hidden");
}

function closeModal() {
    document.getElementById("modal").classList.add("hidden");
}

// 🔹 Ordenamiento de la Tabla (ahora prioriza fechas de pago en orden cronológico)
function ordenarTabla(columna) {
    let tabla = document.getElementById("tabla");
    let filas = Array.from(tabla.getElementsByTagName("tr")).slice(1); // Ignorar encabezado
    let ascendente = tabla.getAttribute("data-orden") !== "asc";

    filas.sort((filaA, filaB) => {
        let celdaA = filaA.getElementsByTagName("td")[columna].innerText.toLowerCase();
        let celdaB = filaB.getElementsByTagName("td")[columna].innerText.toLowerCase();

        if (columna === 3) { // Ordenar por fecha de pago
            let fechaA = new Date(celdaA.split("-").reverse().join("-"));
            let fechaB = new Date(celdaB.split("-").reverse().join("-"));
            return ascendente ? fechaA - fechaB : fechaB - fechaA;
        }

        if (!isNaN(parseFloat(celdaA)) && !isNaN(parseFloat(celdaB))) {
            return ascendente ? celdaA - celdaB : celdaB - celdaA;
        }

        return ascendente ? celdaA.localeCompare(celdaB) : celdaB.localeCompare(celdaA);
    });

    tabla.setAttribute("data-orden", ascendente ? "asc" : "desc");

    let tbody = document.getElementById("tablaPagos");
    tbody.innerHTML = "";
    filas.forEach(fila => tbody.appendChild(fila));
}
