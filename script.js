fetch('https://s4ujomap4c.execute-api.eu-north-1.amazonaws.com/default/resume-counter-func')
    .then(response => response.json())
    .then(data => {
        document.getElementById('counter').innerText = data.count;
    })
    .catch(error => console.error('Hata:', error));