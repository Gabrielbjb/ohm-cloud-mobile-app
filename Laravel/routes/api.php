<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\MemberController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\OrderdetailsController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\SliderController;
use App\Http\Controllers\SubcategoryController;
use App\Http\Controllers\TestimoniController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\PaymentMobileController;
use App\Http\Controllers\OrderMobileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::group([
    "middleware" => "api",
    "prefix" => "auth"
],function(){
    Route::post("admin",[AuthController::class,"login"]);
    Route::post("register",[AuthController::class,"register"]);
    Route::post("login",[AuthController::class,"login_member"]);
    Route::post("login_member",[AuthController::class,"login_member_response"]);
    Route::post("logout",[AuthController::class,"logout"]);
});

Route::group([
    "middleware"=> "api",
],function(){
    Route::resources([ 
        "categories"=>CategoryController::class,
        "subcategories"=>SubcategoryController::class,
        "sliders"=>SliderController::class,
        "products"=>ProductController::class,
        "members"=>MemberController::class,
        "testimonis"=>TestimoniController::class,
        "reviews"=>ReviewController::class,
        "orders"=>OrderController::class,
        "orderdetails"=>OrderdetailsController::class,
        "payments"=>PaymentController::class,
        "cart"=>CartController::class,
        "ordersmobile"=>OrderMobileController::class,
        "paymentsmobile"=>PaymentMobileController::class,
    ]);

    Route::get('pesanan/baru', [OrderController::class, 'baru']);
    Route::get('pesanan/dikonfirmasi', [OrderController::class, 'dikonfirmasi']);
    Route::get('pesanan/dikemas', [OrderController::class, 'dikemas']);
    Route::get('pesanan/dikirim', [OrderController::class, 'dikirim']);
    Route::get('pesanan/diterima', [OrderController::class, 'diterima']);
    Route::get('pesanan/selesai', [OrderController::class, 'selesai']);

    Route::post('pesanan/ubah_status/{order}', [OrderController::class, 'ubah_status']);
    Route::post('pesanan/ubah_statusMobile/{order}', [OrderMobileController::class, 'ubah_statusMobile']);
    
    Route::get('reports',[ReportController::class,'get_reports']);
});