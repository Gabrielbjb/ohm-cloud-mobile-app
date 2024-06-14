<?php

namespace App\Http\Controllers;
use App\Models\OrderDetail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class OrderdetailsController extends Controller
{
    //
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $orderdetail = OrderDetail::all();

        return response()->json([
            'data' => $orderdetail
        ]);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            "id_order" => "required",
            "id_produk" => "required",
            "jumlah" => "required",
            "color" => "required",
            "total" => "required"
        ]);
        if ($validator->fails()) {
            return response()->json(
                $validator->errors(),
                422
            );
        }
    
        $input = $request->all();
    
        $orderdetail = OrderDetail::create($input);
    
        return response()->json([
            'success' => true,
            'data' => $orderdetail
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\OrderDetail  $orderdetail
     * @return \Illuminate\Http\Response
     */
    public function show(OrderDetail $orderdetail)
    {
        return response()->json([
            'data' => $orderdetail
        ]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\OrderDetail  $orderdetail
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, OrderDetail $orderdetail)
    {

        $validator = Validator::make($request->all(),[
            "id_order" => "required",
            "id_produk" => "required",
            "jumlah" => "required",
            "color" => "required",
            "total" => "required"
        ]);

        if ($validator->fails()) {
            return response()->json(
                $validator->errors(),
                422
            );
        }

        $input = $request->all();

        $orderdetail->update($input);

        return response()->json([
            'success' => true,
            'message' => 'success',
            'data' => $orderdetail
        ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\OrderDetail  $orderdetail
     * @return \Illuminate\Http\Response
     */
    public function destroy(OrderDetail $orderdetail)
    {
        $orderdetail->delete();

        return response()->json([
            'success' => true,
            'message' => 'success'
        ]);
    }
}