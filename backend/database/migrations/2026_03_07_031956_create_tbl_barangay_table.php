<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tbl_barangay', function (Blueprint $table) {
            $table->id('Barangay_id');
            $table->unsignedBigInteger('Town_id');
            $table->string('Barangay_name');
            $table->timestamp('Created_at')->useCurrent();
            $table->timestamp('Updated_at')->useCurrent()->useCurrentOnUpdate();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_barangay');
    }
};
