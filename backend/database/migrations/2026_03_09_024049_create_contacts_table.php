<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Patakbuhin ang database migrations para sa tbl_contact.
     * Ang table na ito ay maglalaman ng mga hotline number kada branch.
     */
    public function up(): void
    {
        Schema::create('tbl_contact', function (Blueprint $table) {
            $table->id(); // Auto increment primary key
            $table->string('branch_office'); // Pangalan ng branch
            $table->string('contact_no'); // Contact number ng branch
            $table->timestamps(); // Magdadagdag ng created_at at updated_at
        });
    }

    /**
     * I-reverse ang ginawang migration kung sakaling kailangan i-rollback.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_contact');
    }
};
