<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    //
    public function __construct(){
        //$this->middleware("auth:api")->except(["index"]);
    }
    public function get_reports(Request $request){
        $report = DB::table('orders')
        ->where('status', '=', 'Selesai')
        ->where('created_at', '>=', $request->dari)
        ->where('created_at', '<=', $request->sampai)
        ->get();
        return response()->json([
            'data'=>$report
        ]);
    }

    public function index(){
        return view('report.index');
    }
}
