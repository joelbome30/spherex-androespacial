const filtros = document.querySelectorAll('[data-filtro]');
const noticias = document.querySelectorAll('.noticia');
const cabecera = document.querySelector('.cabecera');
const botonMenu = document.querySelector('.boton-menu');

function cerrarMenu() {
  cabecera.classList.remove('menu-abierto');
  botonMenu.setAttribute('aria-expanded', 'false');
  botonMenu.setAttribute('aria-label', 'Open menu');
}

botonMenu.addEventListener('click', () => {
  const abierto = cabecera.classList.toggle('menu-abierto');
  botonMenu.setAttribute('aria-expanded', String(abierto));
  botonMenu.setAttribute('aria-label', abierto ? 'Close menu' : 'Open menu');
});

document.querySelectorAll('.cabecera a').forEach(enlace => {
  enlace.addEventListener('click', cerrarMenu);
});

document.addEventListener('keydown', evento => {
  if (evento.key === 'Escape' && cabecera.classList.contains('menu-abierto')) {
    cerrarMenu();
    botonMenu.focus();
  }
});

cabecera.classList.add('menu-listo');

filtros.forEach(boton => {
  boton.addEventListener('click', () => {
    const filtro = boton.dataset.filtro;

    filtros.forEach(opcion => {
      opcion.setAttribute('aria-pressed', String(opcion === boton));
    });

    noticias.forEach(noticia => {
      noticia.hidden = filtro !== 'todas' && noticia.dataset.tipo !== filtro;
    });
  });
});
