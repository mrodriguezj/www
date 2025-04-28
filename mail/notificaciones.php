<?php
require_once __DIR__ . '/env_loader.php'; // Cargar el entorno si es necesario aquí
cargarEnv(); // ¡Asegúrate de cargar el .env aquí!
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Formulario de Notificación de Adeudo</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      padding: 20px;
    }
    .formulario {
      background-color: #ffffff;
      padding: 20px;
      border-radius: 8px;
      max-width: 600px;
      margin: auto;
      box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
    }
    h2 {
      text-align: center;
      color: #2E402D;
    }
    .banner-prueba {
      background-color: #ffecb3;
      color: #8a6d3b;
      padding: 10px;
      text-align: center;
      margin-bottom: 20px;
      border-radius: 5px;
      font-weight: bold;
    }
    .form-group {
      margin-bottom: 15px;
    }
    label {
      font-weight: bold;
      display: block;
      margin-bottom: 5px;
    }
    input[type="text"],
    input[type="email"],
    input[type="file"] {
      width: 100%;
      padding: 8px;
      border: 1px solid #ccc;
      border-radius: 4px;
      background-color: #f8f8f8;
    }
    input[readonly] {
      color: #555;
    }
    .pdf-preview {
      margin-top: 10px;
      font-size: 14px;
      color: #333;
    }
    #pdfViewerContainer {
      margin-top: 10px;
      display: none;
    }
    iframe {
      width: 100%;
      height: 300px;
      border: 1px solid #ccc;
      border-radius: 4px;
    }
    button {
      background-color: #2E402D;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 5px;
      font-size: 16px;
      cursor: pointer;
      width: 100%;
    }
    button:hover {
      background-color: #3f5c3b;
    }
  </style>
</head>
<body>

<div class="formulario">
  
  <?php if ($_ENV['MAIL_TEST_MODE'] === 'true'): ?>
    <div class="banner-prueba">
      ⚠️ Estás en MODO PRUEBA.<br>Todos los correos serán enviados a: <br><strong><?php echo $_ENV['MAIL_TEST_ADDRESS']; ?></strong>
    </div>
  <?php endif; ?>

  <h2>Notificar Adeudo</h2>

  <form id="formAdeudo" method="POST" action="enviar_adeudo.php" enctype="multipart/form-data">

    <div class="form-group">
      <label for="id_calendario">ID de Calendario:</label>
      <input type="text" id="id_calendario" name="id_calendario" required>
    </div>

    <div class="form-group">
      <label for="nombre_cliente">Nombre del Cliente:</label>
      <input type="text" id="nombre_cliente" name="nombre_cliente" readonly>
    </div>

    <div class="form-group">
      <label for="correo">Correo electrónico:</label>
      <input type="email" id="correo" name="correo" readonly>
    </div>

    <div class="form-group">
      <label for="lote">Número de Lote:</label>
      <input type="text" id="lote" name="lote" readonly>
    </div>

    <div class="form-group">
      <label for="fecha_vencimiento">Fecha de Vencimiento:</label>
      <input type="text" id="fecha_vencimiento" name="fecha_vencimiento" readonly>
    </div>

    <div class="form-group">
      <label for="monto_pendiente">Monto Pendiente:</label>
      <input type="text" id="monto_pendiente" name="monto_pendiente" readonly>
    </div>

    <div class="form-group">
      <label for="dias_atraso">Días de Atraso:</label>
      <input type="text" id="dias_atraso" name="dias_atraso" readonly>
    </div>

    <div class="form-group">
      <label for="archivo_pdf">Adjuntar PDF (opcional):</label>
      <input type="file" id="archivo_pdf" name="archivo_pdf" accept="application/pdf">
      <div class="pdf-preview" id="pdfPreview">Ningún archivo seleccionado.</div>
      <div id="pdfViewerContainer">
        <iframe id="pdfViewer"></iframe>
      </div>
    </div>

    <input type="hidden" id="mail_test_mode" value="<?php echo ($_ENV['MAIL_TEST_MODE'] === 'true') ? 'true' : 'false'; ?>">
    <input type="hidden" id="correo_prueba" value="<?php echo $_ENV['MAIL_TEST_ADDRESS']; ?>">

    <div class="form-group">
      <button type="button" onclick="confirmarEnvio()">Enviar Notificación</button>
    </div>

  </form>
</div>

<script>
const idInput = document.getElementById('id_calendario');
const pdfInput = document.getElementById('archivo_pdf');
const pdfPreview = document.getElementById('pdfPreview');
const pdfViewerContainer = document.getElementById('pdfViewerContainer');
const pdfViewer = document.getElementById('pdfViewer');

idInput.addEventListener('change', () => {
    const id = idInput.value.trim();
    if (id) {
      fetch(`buscar_info_adeudo.php?id_calendario=${id}`)
        .then(res => res.json())
        .then(data => {
          if (data.success) {
            document.getElementById('nombre_cliente').value = data.nombre_cliente;
            document.getElementById('correo').value = data.correo;
            document.getElementById('lote').value = data.lote;
            document.getElementById('fecha_vencimiento').value = data.fecha_vencimiento;
            document.getElementById('monto_pendiente').value = data.monto_pendiente;
            document.getElementById('dias_atraso').value = data.dias_atraso;
          } else {
            alert('No se encontró información para el ID ingresado.');
            document.getElementById('formAdeudo').reset();
          }
        })
        .catch(() => {
          alert('Error en la consulta.');
        });
    }
});

pdfInput.addEventListener('change', () => {
    const file = pdfInput.files[0];
    if (file && file.type === 'application/pdf') {
      pdfPreview.textContent = `Archivo seleccionado: ${file.name}`;
      const fileURL = URL.createObjectURL(file);
      pdfViewer.src = fileURL;
      pdfViewerContainer.style.display = 'block';
    } else {
      pdfPreview.textContent = 'Ningún archivo seleccionado.';
      pdfViewerContainer.style.display = 'none';
    }
});

function confirmarEnvio() {
    const correoCliente = document.getElementById('correo').value;
    const mailTestMode = document.getElementById('mail_test_mode').value;
    const correoPrueba = document.getElementById('correo_prueba').value;

    let mensajeConfirmacion = "";

    if (mailTestMode === "true") {
        mensajeConfirmacion = `⚠️ Estás en MODO PRUEBA.\nEl correo se enviará a:\n${correoPrueba}\n\n¿Deseas continuar?`;
    } else {
        mensajeConfirmacion = `📧 El correo se enviará a:\n${correoCliente}\n\n¿Confirmas el envío?`;
    }

    if (confirm(mensajeConfirmacion)) {
        document.getElementById('formAdeudo').submit();
    }
}
</script>

</body>
</html>
