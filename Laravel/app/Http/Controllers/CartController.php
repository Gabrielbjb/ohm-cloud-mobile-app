<?php

namespace App\Http\Controllers;
use App\Models\Cart;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    //
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $cart = cart::all();

        return response()->json([
            'data' => $cart
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
            "id_member" => "required",
            "id_barang" => "required",
            "jumlah" => "required",
            "size" => "required",
            "color" => "required",
            "total" => "required",
            "is_checkout" => "required"
        ]);
        if ($validator->fails()) {
            return response()->json(
                $validator->errors(),
                422
            );
        }
    
        $input = $request->all();
    
        $cart = Cart::create($input);
    
        return response()->json([
            'success' => true,
            'data' => $cart
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Cart  $cart
     * @return \Illuminate\Http\Response
     */
    public function show(Cart $cart)
    {
        return response()->json([
            'data' => $cart
        ]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Cart  $cart
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Cart $cart)
    {
        $validator = Validator::make($request->all(), [
            "is_checkout" => "required|boolean" // Only validate the is_checkout field
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Update only the is_checkout field
        $cart->update([
            'is_checkout' => $request->is_checkout
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Cart updated successfully',
            'data' => $cart
        ]);
    }




    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Cart  $cart
     * @return \Illuminate\Http\Response
     */
    public function destroy(Cart $cart)
    {
        $cart->delete();

        return response()->json([
            'success' => true,
            'message' => 'success'
        ]);
    }
}
