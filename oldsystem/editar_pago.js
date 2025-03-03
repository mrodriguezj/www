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
            return;
        }

        // Precargar valores en los campos del formulario
        document.getElementById("id_lote").value = data.id_lote;
        document.getElementById("concepto").value = data.concepto;
        document.getElementById("monto").value = data.monto;
        document.getElementById("fecha_pago").value = data.fecha_pago;
        document.getElementById("metodo_pago").value = data.metodo_pago;
        document.getElementById("folio_pago").value = data.folio_pago || "";
        document.getElementById("banco").value = data.banco;
        document.getElementById("periodo_pago").value = data.periodo_pago;
        document.getElementById("observaciones").value = data.observaciones || "";
    } catch (error) {
        showModal("Error", "Error en la consulta: " + error.message);
    }
});

// 🔹 Enviar actualización de pago
document.getElementById("editarForm").addEventListener("submit", async function (event) {
    event.preventDefault();

    let idPago = document.getElementById("id_pago").value;
    let idLote = document.getElementById("id_lote").value;

    let formData = {
        id_pago: idPago,
        id_lote: idLote,
        concepto: document.getElementById("concepto").value,
        monto: document.getElementById("monto").value,
        fecha_pago: document.getElementById("fecha_pago").value,
        metodo_pago: document.getElementById("metodo_pago").value,
        folio_pago: document.getElementById("folio_pago").value,
        banco: document.getElementById("banco").value,
        periodo_pago: document.getElementById("periodo_pago").value,
        observaciones: document.getElementById("observaciones").value
    };

    try {
        let response = await fetch("/oldsystem/actualizar_pago.php", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(formData)
        });

        let result = await response.json();
        showModal(result.success ? "Éxito" : "Error", result.success || result.error);

        // 🔹 Si la actualización fue exitosa, limpiar el formulario
        if (result.success) {
            limpiarFormulario();
        }
    } catch (error) {
        showModal("Error", "Error en la actualización: " + error.message);
    }
});

// 🔹 Función para limpiar el formulario después de actualizar
function limpiarFormulario() {
    let campos = ["id_pago", "id_lote", "concepto", "monto", "fecha_pago", "metodo_pago", "folio_pago", "banco", "periodo_pago", "observaciones"];
    campos.forEach(id => {
        let campo = document.getElementById(id);
        if (campo) campo.value = ""; // Evita errores si algún campo no existe
    });

    console.log("Formulario limpiado correctamente"); // Depuración en consola
}

// 🔹 Función para mostrar mensajes en el modal
function showModal(title, message) {
    document.getElementById("modal-title").innerText = title;
    document.getElementById("modal-message").innerText = message;
    document.getElementById("modal").classList.remove("hidden");
}

// 🔹 Función para cerrar el modal
function closeModal() {
    document.getElementById("modal").classList.add("hidden");
}
