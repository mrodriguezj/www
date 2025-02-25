// Captura de errores JS
(function() {
    //const API_URL = '../../../api/errores/log_js_error.php'; //RUTA DEFINITIVA
    const API_URL = '/api/errores/log_js_error.php';
  
    // Función para enviar errores al servidor
    function enviarError(mensaje, archivo, linea, columna, stack) {
      fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          mensaje,
          archivo,
          linea,
          columna,
          stack,
          navegador: navigator.userAgent,
          url: window.location.href,
          fecha: new Date().toISOString(),
        }),
      }).catch(() => console.error('No se pudo registrar el error en el servidor.'));
    }
  
    // Captura errores globales
    window.onerror = function(mensaje, archivo, linea, columna, error) {
      enviarError(mensaje, archivo, linea, columna, error?.stack);
    };
  
    // Captura errores en promesas no manejadas
    window.addEventListener('unhandledrejection', function(event) {
      enviarError(event.reason?.message || 'Error en promesa no manejada', '', '', '', event.reason?.stack);
    });
  })();
  