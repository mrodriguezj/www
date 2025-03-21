import { consumirAPI } from './api.js';

export async function cargarResumenHistorico() {
  const data = await consumirAPI('resumen_historico');
  if (!data) return;

  document.getElementById("totalCobradoHistorico").textContent = `$${parseFloat(data.total_cobrado).toLocaleString()}`;
  document.getElementById("carteraVencidaHistorico").textContent = `$${parseFloat(data.cartera_vencida).toLocaleString()}`;
  document.getElementById("porcentajeRecuperacionHistorico").textContent = `${data.porcentaje_recuperacion}%`;
}

export async function cargarProyeccionPeriodo(mes, anio) {
  const data = await consumirAPI(`proyeccion_periodo`, `&mes=${mes}&anio=${anio}`);
  if (!data) return;

  document.getElementById("proyeccionCobroPeriodo").textContent = `$${parseFloat(data.proyeccion_cobro).toLocaleString()}`;
  document.getElementById("carteraVencidaPeriodo").textContent = `$${parseFloat(data.cartera_vencida_periodo).toLocaleString()}`;
  document.getElementById("porcentajeRecuperacionPeriodo").textContent = `${data.porcentaje_recuperacion_periodo}%`;
}
