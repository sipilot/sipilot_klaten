import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

export default class extends Controller {
    connect () {
        this.charts()
    }

    charts () {
        Highcharts.chart('chart-container', {
            chart: {
              type: 'column'
            },
            title: {
              text: 'Rekap Permohonan'
            },
            xAxis: {
              categories: [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec'
              ],
              crosshair: true
            },
            yAxis: {
              min: 0,
              title: {
                text: 'Total'
              }
            },
            tooltip: {
              headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
              pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                '<td style="padding:0"><b>{point.y:.1f} mm</b></td></tr>',
              footerFormat: '</table>',
              shared: true,
              useHTML: true
            },
            plotOptions: {
              column: {
                pointPadding: 0.2,
                borderWidth: 0
              }
            },
            series: [
              {
                name: 'Revisi',
                data: [1]
          
              },
              {
                name: 'Proses',
                data: [1, 2, 3, 4, 5, 6, 7, 8, 9]
              },
              {
                name: 'Selesai',
                data: [1, 2, 3, 4, 5, 6, 7, 8, 9]
            }
          ]
        }
      );
    }
}
