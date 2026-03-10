<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Patakbuhin ang database migrations para sa tbl_directories.
     * Ito ay maglalaman ng Board of Directors at Management team.
     */
    public function up(): void
    {
        Schema::create('tbl_directories', function (Blueprint $table) {
            $table->id();
            $table->string('director_name'); // Pangalan ng director o management personnel
            $table->string('position'); // Posisyon nila sa ISELCO
            $table->string('area')->nullable(); // Anong area naka-assign (pwedeng null sa management)
            $table->string('category')->default('board'); // board o management para madali i-filter
            $table->timestamps();
        });
    }

    /**
     * I-reverse ang migration kung kailangan i-rollback.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_directories');
    }
};
