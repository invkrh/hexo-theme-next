/**
 * note.js | https://theme-next.org/docs/tag-plugins/note/
 */

/* global hexo */

'use strict';

function plot(args, content) {
  var [title, start, stop, step] = args;
  var id =  "chart-"+ Math.floor(Math.random() * 10);
  // return content;
  return `
  <div id="${id}" style="height: 100%; width: 100%"></div>
  <script>

  var xArr = [];
  for (var i = ${start}; ${step} > 0 ? i < ${stop} : i > ${stop}; i += ${step}) {
      xArr.push(i);
  }
  var func = new Function('x', 'return ${content}');
  var yArr = xArr.map(func);

  var trace = {
      mode: 'lines',
      x: xArr,
      y: yArr,
      line: {
        color: '#FF4081',
        width: 2
      }
  };

  var data = [ trace ];

  var layout = {
    title: '${title}',
    margin: {
      l: 0,
      r: 0
    }
  };

  var config = {
    responsive: false,
    staticPlot: true,
    displayModeBar: false
  }

  Plotly.newPlot('${id}', data, layout, config);
  </script>
  `;
}

hexo.extend.tag.register('plot', plot, {ends: true});
