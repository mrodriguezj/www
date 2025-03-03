fetch("localhost/api/index.php?endpoint=clientes", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
        nombres: "Juan",
        apellido_paterno: "Pérez",
        apellido_materno: "López",
        correo_electronico: "juan.perez@example.com",
        telefono: "5551234567",
        curp: "CURP12345678901234",
        rfc: "RFC123456XYZ",
        ine: "INE1234567890123456"
    })
})
.then(res => res.json())
.then(data => console.log(data))
.catch(err => console.error("Error:", err));
