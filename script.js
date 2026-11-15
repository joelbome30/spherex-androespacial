const filtros = document.querySelectorAll('[data-filtro]');
const noticias = document.querySelectorAll('.noticia');

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
