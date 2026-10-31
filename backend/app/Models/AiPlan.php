<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $user_id
 * @property string $prompt
 * @property array<string, mixed>|null $hasil
 * @property string $status
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 */
class AiPlan extends Model
{
    /** @use HasFactory<\Database\Factories\AiPlanFactory> */
    use HasFactory;

    protected $fillable = ['prompt', 'hasil', 'status'];

    protected $casts = [
        'hasil' => 'array',
    ];

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
