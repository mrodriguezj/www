document.getElementById("pagoForm").addEventListener("submit", async function (event) {
    event.preventDefault();

    let selects = ["concepto", "metodo_pago", "banco", "periodo_pago"];
    for (let id of selects) {
        if (document.getElementById(id).value === "") {
            showModal("Error", "Por favor, selecciona una opción válida en todos los campos obligatorios.");
            return;
        }
    }

    let formData = {
        id_lote: document.getElementById("id_lote").value,
        concepto: document.getElementById("concepto").value,
        monto: document.getElementById("monto").value,
        fecha_pago: document.getElementById("fecha_pago").value,
        metodo_pago: document.getElementById("metodo_pago").value,
        folio_pago: document.getElementById("folio_pago").value || null,
        banco: document.getElementById("banco").value,
        periodo_pago: document.getElementById("periodo_pago").value,
        observaciones: document.getElementById("observaciones").value || null
    };

    try {
        let response = await fetch("/oldsystem/registrar_pago.php", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(formData)
        });

        let result = await response.json();
        showModal(result.success ? "Éxito" : "Error", result.success || result.error);

        if (result.success) {
            document.getElementById("pagoForm").reset();
        }
    } catch (error) {
        showModal("Error", "Error en la solicitud: " + error.message);
    }
});

// Función para manejar el modal
function showModal(title, message) {
    document.getElementById("modal-title").innerText = title;
    document.getElementById("modal-message").innerText = message;
    document.getElementById("modal").classList.remove("hidden");
}

function closeModal() {
    document.getElementById("modal").classList.add("hidden");
}
