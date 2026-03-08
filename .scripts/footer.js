// change subfolder links to relative links
const startsWith = 'https://github.com/scottj/agent-research/tree/main/';
const endsWith = '#readme';
const links = document.querySelectorAll('a[href]');
links.forEach(link => {
    const href = link.getAttribute('href');
    const matchesStart = startsWith ? href.startsWith(startsWith) : true;
    const matchesEnd = endsWith ? href.endsWith(endsWith) : true;

    if (matchesStart && matchesEnd) {
        const href = link.getAttribute('href');
        const marker = '/tree/main/';
        const idx = href.indexOf(marker);
        if (idx === -1) return;
        const tail = href.substring(idx + marker.length).split('#')[0].split('?')[0];
        link.setAttribute('href', tail + '/');
    }
});
