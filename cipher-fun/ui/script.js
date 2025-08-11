let audioPlayer = null;
const tiemposObjetivo = [22, 40, 70, 132, 150, 180];
const enviados = {};

$(document).ready(function () {
  console.log("ready")
  $.post(`https://${GetParentResourceName()}/ready`)
});

function typeText(element, sequence, speed, callback) {
  const textNode = document.createElement('span');
  const cursorNode = document.createElement('span');
  cursorNode.classList.add('typer-cursor');
  cursorNode.textContent = '|';

  element.textContent = '';
  element.appendChild(textNode);
  element.appendChild(cursorNode);

  let index = 0;

  function processNext() {
    if (index >= sequence.length) {
      cursorNode.remove();
      if (typeof callback === 'function') callback();
      return;
    }

    const { text, time, delay } = sequence[index];
    let i = 0;

    const typingInterval = setInterval(() => {
      if (i < text.length) {
        textNode.textContent += text.charAt(i);
        i++;
      } else {
        clearInterval(typingInterval);
        setTimeout(() => {
          let j = text.length;
          const deletingInterval = setInterval(() => {
            if (j > 0) {
              textNode.textContent = text.slice(0, j - 1);
              j--;
            } else {
              clearInterval(deletingInterval);
              setTimeout(() => {
                index++;
                processNext();
              }, delay);
            }
          }, speed);
        }, time);
      }
    }, speed);
  }

  processNext();
}

window.addEventListener("message", function (event) {
  if (event.data.action === "play") {
    if (audioPlayer !== null) {
      audioPlayer.pause();
      audioPlayer.currentTime = 0;
    }

    const el = document.getElementById('typer');
    typeText(el, [
      { text: 'Hola, soy Álvaro', time: 5000, delay: 1000 },
      { text: 'Solo quería hacerte saber que algo muy especial está a punto de pasar', time: 4000, delay: 100 },
      { text: 'No te preocupes, todo estará bien.', time: 3000, delay: 100 }
    ], 10);

    tiemposObjetivo.forEach(t => enviados[t] = false);

    audioPlayer = new Audio(`cipher.mp3`);
    audioPlayer.volume = 0.6;

    audioPlayer.addEventListener("timeupdate", () => {
      const tiempo = Math.floor(audioPlayer.currentTime);

      if (tiemposObjetivo.includes(tiempo) && !enviados[tiempo]) {
        $.post(`https://${GetParentResourceName()}/time`, JSON.stringify({
          segundo: tiempo
        }));

        if (tiempo == 70) {
          $(".container img").css("position", "fixed")
          typeText(el, [
            { text: 'Hola, soy Álvaro de nuevo', time: 5000, delay: 1000 },
            { text: '¿te ha gustado el evento canónico? quiero ver el clip en cuanto acabe', time: 4000, delay: 4000 },
            { text: 'por cierto, aguanta que hay parte 2. ', time: 8000, delay: 100 }
          ], 10, () => {
            $(".container img").css("position", "")
          });
        }
        enviados[tiempo] = true;
      }

      tiemposObjetivo.forEach(t => {
        if (tiempo < t) enviados[t] = false;
      });
    });

    audioPlayer.play();
  }

    if (event.data.action === "showlogo") {
      const img = $('<img>', {
        src: 'e.png',
        css: {
          height: '150px'
        }
      });
      $('.container').prepend(img);
    }

  if (event.data.action === 'reload') {
    location.reload();
  }
});