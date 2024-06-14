@extends('layout.app')

@section('title', 'Dashboard')

@section('content')

<div style="display: flex; flex-wrap: wrap;">
    <div id="myChart" style="width:100%; max-width:600px; height:500px;"> </div>
    <div id="myChartPembayaran" style="width:100%; max-width:600px; height:500px;"> </div>
</div>
@endsection


@push('js')
<script src="https://www.gstatic.com/charts/loader.js"></script>
<script>
    const results = [['Barang', 'Total']];
    google.charts.load('current', {'packages':['corechart']});
    const token = localStorage.getItem('token');
    $(function() {
        const apiEndpoints = [
            '/api/pesanan/dikemas',
            '/api/pesanan/dikirim',
            '/api/pesanan/dikonfirmasi',
            '/api/pesanan/diterima',
            '/api/pesanan/baru',
            '/api/pesanan/selesai'
        ];
        
        const fetchEndpointData = async (endpoint) => {
            try {
                const response = await $.ajax({
                    url: endpoint,
                    headers: {
                        "Authorization": 'Bearer ' + token
                    }
                });
                results.push([endpoint.split('/').pop(), response.data.length]);
            } catch (error) {
                console.error("Error fetching data for", endpoint, ":", error);
                results.push([endpoint.split('/').pop(), 0]);
            }
        };

        const fetchAllEndpointData = async () => {
            for (const endpoint of apiEndpoints) {
                await fetchEndpointData(endpoint);
            }
            google.charts.setOnLoadCallback(drawChart1);
        };

        fetchAllEndpointData();
    });
    $(function() {
        $.ajax({
            url: '/api/payments',
            success: function({
                data
            }) {
                let statusCounts = {};
                console.log(data);
                data.forEach(item => {
                    if (statusCounts[item.status]) {
                        statusCounts[item.status]++;
                    } else {
                        statusCounts[item.status] = 1;
                    }
                });

                // Mengonversi objek menjadi array
                let resultnya = Object.entries(statusCounts).map(([status, count]) => {
                    return [status, count];
                });

                let result2 = [['Pembayaran', 'Status'], ...resultnya];
                google.charts.setOnLoadCallback(drawChart2(result2));
                
            }
        });
    });

    function drawChart1() {

        const data = google.visualization.arrayToDataTable(results);

        const options = {
            title:'Informasi Pesanan'
        };

        const chart = new google.visualization.PieChart(document.getElementById('myChart'));
        chart.draw(data, options);

    }
    function drawChart2(result2) {

        const data = google.visualization.arrayToDataTable(result2);

        const options = {
            title:'Informasi Pembayaran'
        };

        const chart = new google.visualization.PieChart(document.getElementById('myChartPembayaran'));
        chart.draw(data, options);

}
</script>

@endpush
