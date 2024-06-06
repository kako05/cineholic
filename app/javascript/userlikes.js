document.addEventListener('turbo:load', function() {
  document.querySelectorAll('.like-button').forEach(function(button) {
    button.addEventListener('click', function(event) {
      event.preventDefault();
      var filmId = this.id.split('_')[2];
      var filmElement = document.getElementById('film_' + filmId);
      
      fetch(this.href, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          throw new Error('Network response was not ok.');
        }
      })
      .then(data => {
        if (data.status === 'success') {
          filmElement.parentNode.removeChild(filmElement);
        } else {
          console.error('Error: Unable to delete like.');
        }
      })
      .catch(error => {
        console.error('There was a problem with the fetch operation:', error);
      });
    });
  });
});