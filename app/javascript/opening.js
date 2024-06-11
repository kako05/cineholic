function post() {
  const videoElement = document.getElementById('opening-video');

  if (videoElement) {
    // ローカルストレージをチェック
    const hasVisited = localStorage.getItem('hasVisited');

    // 初めてのアクセスなら動画を再生
    if (!hasVisited) {
      // データ属性からパスを取得
      const webmSource = videoElement.getAttribute('data-webm');
      const mp4Source = videoElement.getAttribute('data-mp4');

      // ブラウザを検出
      const userAgent = navigator.userAgent;
      if (/Chrome/i.test(userAgent)) {
        // Chromeの場合、WebMソースを使用
        videoElement.src = webmSource;
      } else if (/Safari/i.test(userAgent)) {
        // Safariの場合、MP4ソースを使用
        videoElement.src = mp4Source;
      } else {
        // デフォルトでWebMソースを使用
        videoElement.src = webmSource;
        console.warn('サポートされていないブラウザです。デフォルトのWebMソースを使用します。');
      };

      // 動画終了イベントをリッスン
      videoElement.addEventListener('ended', () => {
        videoElement.classList.add('hidden'); 
        const formContainer = document.querySelector('.contents');
        if (formContainer) {
          formContainer.style.zIndex = 3;
        };
      });

      videoElement.play(); // 動画を再生

      // ローカルストレージに訪問フラグを設定
      localStorage.setItem('hasVisited', 'true');
    } else {
      // 2回目以降なら動画を非表示にして検索フォームを前面に移動
      videoElement.classList.add('hidden');
      const formContainer = document.querySelector('.contents');
      if (formContainer) {
        formContainer.style.zIndex = 3;
      };
    };
  } else {
    console.error('Opening video element not found.');
  };
};

window.addEventListener('turbo:load', post);
window.addEventListener('turbo:render', post);