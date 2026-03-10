<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_incident_reports', function (Blueprint $table) {
            $table->id('Incident_id');
            $table->unsignedBigInteger('User_id')->nullable();
            $table->string('Type_of_incident', 100);
            $table->string('Account_number', 50)->nullable();
            $table->string('Town', 150)->nullable();
            $table->string('Barangay', 150)->nullable();
            $table->string('Sitio', 150)->nullable();
            $table->text('Remarks')->nullable();
            $table->string('Upload_path', 255)->nullable();
            $table->string('Status', 50)->default('PENDING');
            $table->timestamps(); // Created_at, Updated_at
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_incident_reports');
    }
};
