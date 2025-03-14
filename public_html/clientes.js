document.getElementById("clienteForm").addEventListener("submit", function(event) {
    event.preventDefault();

    // Construir objeto con los datos
    const formData = {
        nombres: document.getElementById("nombres").value,
        apellido_paterno: document.getElementById("apellido_paterno").value,
        apellido_materno: document.getElementById("apellido_materno").value || '',
        correo_electronico: document.getElementById("correo_electronico").value,
        telefono: document.getElementById("telefono").value,
        curp: document.getElementById("curp").value,
        rfc: document.getElementById("rfc").value,
        ine: document.getElementById("ine").value,
        direccion: document.getElementById("direccion").value,
        estatus: document.getElementById("estatus").value
    };

    // Enviar los datos a la API
    fetch("http://localhost/api/index.php?endpoint=clientes_v2", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData)
    })
    .then(res => res.json())
    .then(data => {
        const responseMessage = document.getElementById("responseMessage");

        if (data.error) {
            responseMessage.style.color = "red";
            responseMessage.textContent = "❌ " + data.error;
        } else if (data.success) {
            responseMessage.style.color = "green";
            responseMessage.textContent = "✅ " + data.success;
            document.getElementById("clienteForm").reset();
        } else {
            responseMessage.style.color = "red";
            responseMessage.textContent = "❌ Error desconocido. Intenta nuevamente.";
        }
    })
    .catch(error => {
        console.error("Error:", error);
        document.getElementById("responseMessage").style.color = "red";
        document.getElementById("responseMessage").textContent = "❌ Error en la solicitud.";
    });
});
