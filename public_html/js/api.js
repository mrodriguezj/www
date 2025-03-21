export async function consumirAPI(endpoint, params = '') {
    const url = `/api/index.php?endpoint=${endpoint}${params}`;
  
    try {
      const respuesta = await fetch(url);
      if (!respuesta.ok) throw new Error(`HTTP error! Status: ${respuesta.status}`);
  
      const data = await respuesta.json();
      if (!data.success) {
        console.error(`Error en endpoint: ${endpoint}`, data.message);
        return null;
      }
  
      return data.data;
  
    } catch (error) {
      console.error(`Error de conexión en endpoint: ${endpoint}`, error);
      return null;
    }
  }
  