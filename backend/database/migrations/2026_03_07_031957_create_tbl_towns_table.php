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
        Schema::create('tbl_towns', function (Blueprint $table) {
            $table->id('Town_id');
            $table->string('Town_name');
            $table->string('Town_code');
            $table->timestamp('Created_at')->useCurrent();
            $table->timestamp('Updated_at')->useCurrent()->useCurrentOnUpdate();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_towns');
    }
};
