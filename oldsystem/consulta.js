document.getElementById("buscarPago").addEventListener("click", async function () {
    let idPago = document.getElementById("id_pago").value;

    if (!idPago || idPago <= 0) {
        showModal("Error", "Ingrese un ID de pago válido.");
        return;
    }

    try {
        let response = await fetch(`/oldsystem/consulta_pago.php?id_pago=${idPago}`);
        let data = await response.json();

        if (data.error) {
            showModal("Error", data.error);
            limpiarCampos();
        } else {
            document.getElementById("id_lote").value = data.id_lote;
            document.getElementById("concepto").value = data.concepto;
            document.getElementById("monto").value = formatearMoneda(data.monto);
            document.getElementById("fecha_pago").value = formatearFecha(data.fecha_pago);
            document.getElementById("metodo_pago").value = data.metodo_pago;
            document.getElementById("folio_pago").value = data.folio_pago || "N/A";
            document.getElementById("banco").value = data.banco;
            document.getElementById("periodo_pago").value = data.periodo_pago;
            document.getElementById("observaciones").value = data.observaciones || "Sin observaciones";
        }
    } catch (error) {
        showModal("Error", "Error en la consulta: " + error.message);
    }
});

function showModal(title, message) {
    document.getElementById("modal-title").innerText = title;
    document.getElementById("modal-message").innerText = message;
    document.getElementById("modal").classList.remove("hidden");
}

function closeModal() {
    document.getElementById("modal").classList.add("hidden");
}

function limpiarCampos() {
    let campos = ["id_lote", "concepto", "monto", "fecha_pago", "metodo_pago", "folio_pago", "banco", "periodo_pago", "observaciones"];
    campos.forEach(id => document.getElementById(id).value = "");
}

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
