document.addEventListener("DOMContentLoaded", () => {
    const formPago = document.getElementById("formRegistroPago");
    const mensajePago = document.getElementById("mensajePago");
  
    formPago.addEventListener("submit", async (e) => {
      e.preventDefault();
  
      const idLote = document.getElementById("id_lote_pago").value.trim();
      const fechaPago = document.getElementById("fecha_pago").value.trim();
      const montoPagado = document.getElementById("monto_pagado").value.trim();
      const categoriaPago = document.getElementById("categoria_pago").value;
      const metodoPago = document.getElementById("metodo_pago").value;
      const referenciaPago = document.getElementById("referencia_pago").value.trim();
      const observacionesPago = document.getElementById("observaciones_pago").value.trim();
      const porcentajeComision = document.getElementById("porcentaje_comision").value.trim();
  
      if (!idLote || !fechaPago || !montoPagado || !categoriaPago || !metodoPago || !porcentajeComision) {
        mostrarMensaje("Todos los campos obligatorios deben estar completos.", "error");
        return;
      }
  
      const datosPago = {
        id_lote: idLote,
        fecha_pago: fechaPago,
        monto_pagado: montoPagado,
        categoria_pago: categoriaPago,
        metodo_pago: metodoPago,
        referencia_pago: referenciaPago,
        observaciones: observacionesPago,
        porcentaje_comision: porcentajeComision
      };
  
      console.log("Enviando datos:", datosPago);
  
      try {
        const respuesta = await fetch("/api/index.php?endpoint=registrar_pago", {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify(datosPago)
        });
  
        const resultado = await respuesta.json();
  
        if (resultado.success) {
          mostrarMensaje("✅ Pago registrado correctamente.", "success");
          formPago.reset();
        } else {
          mostrarMensaje(`❌ ${resultado.error || resultado.message}`, "error");
        }
  
      } catch (error) {
        console.error("Error en la solicitud:", error);
        mostrarMensaje("❌ Error al conectar con el servidor.", "error");
      }
    });
  
    function mostrarMensaje(mensaje, tipo) {
      mensajePago.textContent = mensaje;
  
      if (tipo === "success") {
        mensajePago.className = "text-green-600 font-medium mt-4";
      } else {
        mensajePago.className = "text-red-600 font-medium mt-4";
      }
  
      setTimeout(() => {
        mensajePago.textContent = "";
      }, 5000);
    }
  });
  