<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Patakbuhin ang database migrations para sa tbl_management.
     * Ito ay maglalaman ng mga management employees.
     */
    public function up(): void
    {
        Schema::create('tbl_management', function (Blueprint $table) {
            $table->id();
            $table->string('employee_name'); // Pangalan ng employee
            $table->string('position'); // Posisyon sa kumpanya
            $table->string('department'); // Assign department
            $table->timestamps();
        });
    }

    /**
     * I-reverse ang migration kung kailangan i-rollback.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_management');
    }
};
