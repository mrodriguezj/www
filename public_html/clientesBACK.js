document.getElementById("clienteForm").addEventListener("submit", function(event) {
    event.preventDefault();

    // Obtener los valores del formulario
    const formData = {
        nombres: document.getElementById("nombres").value,
        apellido_paterno: document.getElementById("apellido_paterno").value,
        apellido_materno: document.getElementById("apellido_materno").value,
        correo_electronico: document.getElementById("correo_electronico").value,
        telefono: document.getElementById("telefono").value,
        curp: document.getElementById("curp").value,
        rfc: document.getElementById("rfc").value,
        ine: document.getElementById("ine").value
    };

    // Enviar datos a la API usando fetch()
    fetch("http://localhost/api/index.php?endpoint=clientes", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData)
    })
    .then(response => response.json())
    .then(data => {
        const responseMessage = document.getElementById("responseMessage");
        if (data.error) {
            responseMessage.style.color = "red";
            responseMessage.textContent = "❌ Error: " + data.error;
        } else {
            responseMessage.style.color = "green";
            responseMessage.textContent = "✅ " + data.success;
            document.getElementById("clienteForm").reset();
        }
    })
    .catch(error => {
        console.error("Error:", error);
        document.getElementById("responseMessage").textContent = "❌ Error en la solicitud";
    });
});
