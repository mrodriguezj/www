import { cargarProyeccionPeriodo } from './kpis.js';

export function iniciarFiltros() {
  const modal = document.getElementById('modalFiltro');

  document.getElementById('btnAbrirFiltro').addEventListener('click', () => {
    modal.classList.remove('hidden');
    modal.classList.add('flex');
  });

  document.getElementById('btnCerrarFiltro').addEventListener('click', () => {
    modal.classList.add('hidden');
    modal.classList.remove('flex');
  });

  document.getElementById('btnAplicarFiltros').addEventListener('click', () => {
    const mes = document.getElementById('mes').value;
    const anio = document.getElementById('anio').value;

    cargarProyeccionPeriodo(mes, anio);

    modal.classList.add('hidden');
    modal.classList.remove('flex');
  });
}
