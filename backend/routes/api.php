<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TestController;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\TownAndBarangayController;
use App\Http\Controllers\BranchController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\DirectoryController;
use App\Http\Controllers\ManagementController;


// Endpoint para makuha ang user information kung may authentication (Sanctum)
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Ito ang ating custom API endpoint na tatawagin ng frontend at mobile app.
// Iiwasan natin ang spaghetti code sa pamamagitan ng pag-gamit ng Controller.
Route::get('/test-message', [TestController::class, 'getMessage']);


    Route::post('/registration', [UserController::class, 'store']);
    Route::get('/towns', [TownAndBarangayController::class, 'getTowns']);
    Route::get('/barangays/{town_id}', [TownAndBarangayController::class, 'getBarangays']);
    Route::post('/check-email', [UserController::class, 'checkEmail']);
    Route::post('/login', [LoginController::class, 'login']);


      Route::middleware('auth:sanctum')->group(function () {
        Route::post('/toggle-biometric', [LoginController::class, 'toggleBiometric']);
        Route::post('/change-password', [LoginController::class, 'changePassword']);

        // Branches
        Route::get('/branches', [BranchController::class, 'index']);
        Route::get('/branches/{id}', [BranchController::class, 'show']);

        // Contacts / Hotlines
        Route::get('/contacts', [ContactController::class, 'index']);

        // Directories (Board of Directors & Management)
        Route::get('/directories/{category}', [DirectoryController::class, 'getByCategory']);

        // Management List
        Route::get('/management', [ManagementController::class, 'index']);

        // Incident Reports
        Route::post('/incidents', [\App\Http\Controllers\IncidentReportController::class, 'store']);
    });

